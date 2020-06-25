import { BaseEntity, User } from './../../shared';
import { Branch } from '../branch';

export class UserExtra implements BaseEntity {
    constructor(
        public id?: number,
        public name?: string,
        public designation?: string,
        public contactMobile?: string,
        public contactWork?: string,
        public contactOther?: string,
        public createdBy?: string,
        public createdDate?: any,
        public lastModifiedBy?: string,
        public lastModifiedDate?: any,
        public user?: User,
        public roles?: BaseEntity[],
        public institutions?: BaseEntity[],
        public branches?: Branch[]
    ) {
    }
}
